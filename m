From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/19] Cleaning up the IPv6 MTU checking in the IPVS xmit
 code, by using a common helper function __mtu_check_toobig_v6().
Date: Wed, 29 Aug 2012 14:24:39 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208291424050.26100@stinky-local.trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
 <1346190539-9963-3-git-send-email-kaber@trash.net>
 <Pine.LNX.4.64.1208290959010.32281@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1208290959010.32281@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Aug 2012, Jesper Dangaard Brouer wrote:

>
> Just a little nitpick.
>
> The original title/subj was:
> "ipvs: IPv6 MTU checking cleanup and bugfix"
>
> And the curr/used title/subj were part of the commit text.

Sorry, must have happened while importing the patch, I noticed it
afterwards, but was already too late.
