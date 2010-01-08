From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 5/9] snet: introduce snet_event.c and snet_event.h
Date: Fri, 08 Jan 2010 18:51:55 +0100
Message-ID: <m2r5q0jxhg.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-6-git-send-email-sam@synack.fr>
	<20100104190854.GD6034@us.ibm.com> <m2iqbdkqnm.fsf@ssh.synack.fr>
	<20100108153443.GA8117@us.ibm.com> <m2vdfcjxue.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2vdfcjxue.fsf@ssh.synack.fr> (Samir Bellabes's message of "Fri,
	08 Jan 2010 18:44:09 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes <sam@synack.fr> writes:


> No I don't, if it returns 0, we proceed the next event in the current
> list.

To be sure you shall understand: No I don't want to break.
