From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.4
Date: Tue, 16 Jun 2009 16:57:14 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906161655200.10691@fbirervta.pbzchgretzou.qr>
References: <4A3787DB.1040704@trash.net> <x6ski01g7t@gzp> <4A379FC2.7060004@trash.net> <alpine.LSU.2.00.0906161629360.3418@fbirervta.pbzchgretzou.qr> <4A37AE6D.9020900@trash.net> <4A37B20D.7070106@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gabor Z. Papp" <gzp@papp.hu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53030 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758718AbZFPO5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 10:57:12 -0400
In-Reply-To: <4A37B20D.7070106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-06-16 16:54, Patrick McHardy wrote:
>Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>> Nope, see `git show v1.4.4:configure.ac`.
>>> AC_INIT in configure.ac was indeed not updated.
>>>   
>>>     
>>
>> Damn, the release script fooled me. I'll fix up the tarballs.
>
>All should be fixed now, including the git tag.
>

Note to parties: `git tag -d v1.4.4` is needed if you have the old one, 
as git fetch does not force-update tags by default like it does 
branches.
