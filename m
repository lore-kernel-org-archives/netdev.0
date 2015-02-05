From: Josh Hunt <johunt@akamai.com>
Subject: [ANNOUNCE] netdev0.1 netfilter BoF
Date: Wed, 04 Feb 2015 18:17:54 -0600
Message-ID: <54D2B6B2.8070004@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"Bohman, Pete" <pbohman@akamai.com>, kaber@trash.net,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will be leading a BoF discussing netfilter development and issues in 
iptables, ipset, and nftables at netdev0.1 in Ottawa coming up in a few 
weeks.

Our timeslot is currently scheduled for Sunday, Feb 15 @ 9am, but please 
refer to https://www.netdev01.org/schedule in case there are any 
schedule changes.

The topics we intend to cover will be based around Akamai's usage, 
deployment, and the issues we've come across.

Some examples of those topics are:
   * The need for supported interfaces from netfilter components.
   * The handling of large (1 million to 25 million entry) sets, both 
with ipsets and nft sets.
   * Limitations in existing iptables functionality.
     * For ex, issues with hashlimit implementation and proposals to 
extend it.

We'll also look at the current standing of nftables and discuss some 
basic performance as it pertains to our environment, as well as, 
backwards compatibility, and possible new features in nftables.

We hope to bring together interested stakeholders and interested parties 
to discuss the above along with any other related netfilter topics you 
would like to discuss. The BoF is scheduled for two hours.

If you have items you'd like to add to the agenda and/or present, please 
contact me.

Thanks
Josh & Pete
