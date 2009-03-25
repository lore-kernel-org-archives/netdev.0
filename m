From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [ANNOUNCE] iproute2 v2.6.29
Date: Wed, 25 Mar 2009 17:32:02 +0100
Message-ID: <49CA5C82.3000706@hartkopp.net>
References: <20090324153427.3ff0dfdb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:49998 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761146AbZCYQcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 12:32:15 -0400
In-Reply-To: <20090324153427.3ff0dfdb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Trying to stay on top of things (for a change).
> 
> New version of iproute2 utilities that includes bug fixes and
> support for all the new features in kernel 2.6.29.
> 
>   http://devresources.linux-foundation.org/dev/iproute2/download/iproute2-2.6.29.tar.bz2
> 
> Denys Fedoryschenko (1):
>       Fix memory leak in local options
> 
> Jamal Hadi Salim (1):
>       Breakage noticed when debian upgraded to xtables (iptables > 1.4.1)
> 
> Patrick McHardy (1):
>       iproute: add DRR support
> 
> Stephen Hemminger (7):
>       fix uninitialized memory in tc_skbedit
>       Add missing limits.h
>       Add DHCP as routing protocol
>       Add support for IFALIAS
>       Handle default hoplimit
>       Use sanatized headers from 2.6.29
>       Update snapshot

Hi Stephen,

the CAN stuff i mailed to you is still missing.

Sigh.

Oliver

