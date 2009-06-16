From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.4
Date: Tue, 16 Jun 2009 16:54:05 +0200
Message-ID: <4A37B20D.7070106@trash.net>
References: <4A3787DB.1040704@trash.net> <x6ski01g7t@gzp> <4A379FC2.7060004@trash.net> <alpine.LSU.2.00.0906161629360.3418@fbirervta.pbzchgretzou.qr> <4A37AE6D.9020900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Gabor Z. Papp" <gzp@papp.hu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A37AE6D.9020900@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Jan Engelhardt wrote:
>> Nope, see `git show v1.4.4:configure.ac`.
>> AC_INIT in configure.ac was indeed not updated.
>>   
>>     
>
> Damn, the release script fooled me. I'll fix up the tarballs.
>   

All should be fixed now, including the git tag.
