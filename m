From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 19:31:13 +0400
Message-ID: <48E397C1.6050407@openvz.org>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org> <48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com> <1222872885.23573.64.camel@iris.sw.ru> <48E394D2.5090709@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39250 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbYJAPe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:34:27 -0400
In-Reply-To: <48E394D2.5090709@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes per namespace, I agree.
> 
> If the option is controlled by the parent and it is done by sysctl, you 
> will have to make proc/sys per namespace like Pavel did with /proc/net, no ?

/proc/sys is already per namespace actually ;) Or what did you mean by that?
