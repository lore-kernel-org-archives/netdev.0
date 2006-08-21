From: Daniel Drake <dsd@gentoo.org>
Subject: Re: sky2 doesn't receive any packages after I ssh in via ipv6 and
 edit a file in vim (reproducable)
Date: Mon, 21 Aug 2006 23:56:06 +0100
Message-ID: <44EA3A06.9070100@gentoo.org>
References: <20060821212243.GA1558@cip.informatik.uni-erlangen.de> <20060821150231.31a947d4@localhost.localdomain> <20060821222806.GD21790@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:26231 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751273AbWHUWoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 18:44:37 -0400
To: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
In-Reply-To: <20060821222806.GD21790@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Glanzmann wrote:
> I can ssh off the machine for days. But sshing in IPv6 and starting vim
> makes the network card hang.

This is possibly related to an equally strange issue reported on the 
Gentoo bugzilla. As soon as iptables is started, sky2 hangs.

http://bugs.gentoo.org/136508

I'll be sending more details as soon as I have them.

Daniel

