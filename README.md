# GhostBank_Analysis
When a well-known URL for any reason, is no longer associated with the original owner or business, it
becomes a tool to manipulate and monetize unaware users. This idea of “reputation hijacking” pose a great
threat to security of internet today since there are not enough effective policies regarding this issue. The
specific case that motivated the original authors was banking URLs, which is also the basis for our project
here. I updated some of the results of the original paper with a new batch of official data and came up
with some results confirming the findings of the original publication. The most surprising results we found,
compared to the original paper, include domains being hijacked more quickly and the resurrection of more
bank held domains. I deduced that although the rate of closed banks in recent years were low, there are
still many obsolete bank URLs that are being misused to trick the unsuspecting users. The results of the
paper and our project should provide motivation for future research and attract more attention to the
necessity of implementing appropriate policies regarding this issue.

For this project, we are replicating some of the results of the paper “The Ghosts of Banking Past: Empirical
Analysis of Closed Bank Websites” by Tyler Moore and Richard Clayton, which is based on “URL
Reputation Hijacking”. The authors in the paper were answering this question which is also the main
motivation for our project:
What happens to a well-known web address (domain) with a long standing reputation and high rank of
visits when it becomes orphaned and no longer in the same capacity of service as before?
In many cases, that kind of URL becomes an excellent tool to deceive and manipulate visitors by redirecting
them to a new compromised website dedicated to cyber-crime and it turns out that this is the case for many
orphaned banking sector businesses’ websites.
What is the economic impact of this topic? These sites with an established reputation are easier to monetize
because of the existing trust the users have in the website. Since the user’s behavior prediction and
exploitation is the point of interest, any criminal party who would acquire such domain, would be able to
benefit from the initial trust of the users to harvest information or otherwise monetize the site. Unsuspecting
users require less effort for these criminals to monetize.
The purpose of this project is to refresh the data used in the publication of the aforementioned paper. In
doing so, we regenerated and replicated some of the results with new data about these domains since the
paper has been published till present. I came up with new findings about how the previous results have
shifted in direction and what could be the meaning of the observed shifts.
First, we elaborate on the data collection process and describe how and why we gathered data for our
research. I did the data collection using Selenium script, along with Python scripts and C# code. This
way we had them organized in a usable format.
After cleaning and preparing the data, we lay out the analytical approach we took to update and replicate
paper’s results. I was able to reuse part of the R code used in the previous paper to compare the data
with the results of the original paper. I used these data to determine the ownership status of these domains,
in an attempt to see whether they are misused or not.
The detail description and comparison of our results with the original paper is presented at the end. I
concluded that the orphaned domains are still being used maliciously against the users.
