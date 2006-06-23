From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Streamline testing of 802.11 drivers
Date: Fri, 23 Jun 2006 16:56:16 -0400
Message-ID: <43e72e890606231356p24ce16fcwa8c826806eb7c1f6@mail.gmail.com>
References: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ivan Seskar" <Seskar@winlab.rutgers.edu>,
	"Kishore Ramachandran" <kishore@winlab.rutgers.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:1064 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1752003AbWFWU4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:56:18 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1225063ugf
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 13:56:16 -0700 (PDT)
To: netdev@vger.kernel.org, zd1211-devs@lists.sourceforge.net
In-Reply-To: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oh and mini-PCI please :)

On 6/23/06, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> I've mentioned this to a few but here it is out to everyone. So as you
> know we have a lot of work ahead of us for linux wireless development.
> To help speed this up, we at Winlab, would like to start hosting a
> testbed for linux wireless development, open to the public. Short term
> goals would be to start off a couple of nodes for each driver
> currently under development like bcm43xx, zd1211, rt2x00, ipw3945,
> ipw2200 and the like, and a provide a set streamlined tests we can use
> to really put to test the drivers and stacks.
>
> This wouldn't be easy if we didn't have infrastructure but we already
> do. Our grid consists of 400 nodes with 2 wireless cards each and 3
> ethernet ports (one for control) --
> http://orbit-lab.org/wiki/Tutorial/Testbed. 90% of our nodes use the
> atheros 5213 chipset and the rest ipw2200s. We'd like to expand this
> with the more wireless cards currently being worked on for linux.
>
> Right now we have zome zd1211s so we'll start with that (I'll start
> working on a port to d80211) but will try to accomodate other nodes as
> we get more wireless cards. We will need some help too though, to
> streamline the testing. If you have ideas or would like to contribute
> please let me know. We can purchase wireless cards but if you already
> have reliable confirmed wireless cards which can be used for putting
> into the testbed let me know.
>
>   Luis
>
