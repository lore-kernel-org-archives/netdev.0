From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: forcedeth, 2.6.29.1: no link during initialization
Date: Sun, 26 Apr 2009 18:16:04 -0700
Message-ID: <20090426181604.7b38cab0.akpm@linux-foundation.org>
References: <49F066D8.5060802@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: Harald Dunkel <harald.dunkel@t-online.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755456AbZD0BSx@vger.kernel.org>
In-Reply-To: <49F066D8.5060802@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc's added)

On Thu, 23 Apr 2009 15:02:16 +0200 Harald Dunkel <harald.dunkel@t-online.de> wrote:

> Hi folks,
> 
> I get these messages on every boot
> 
> [   37.413903] eth0: no link during initialization.
> [   39.789316] eth0: link up.
> [   39.794965] eth0: link down.
> [   46.438599] eth0: link up.
> [   48.407885] eth0: link down.
> [   52.981754] eth0: link up.
> [   52.986966] eth0: link down.
> 
> After that dhcpclient or network manager give up to try
> again, i.e. the network is not set up.
> 
> 
> I saw this mentioned several times on Google, but without
> a solution. Maybe I could help to track this down?
