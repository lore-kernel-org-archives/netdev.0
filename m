From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 12:56:14 +0400
Message-ID: <4C9B162E.7040201@parallels.com>
References: <m1ocborgq7.fsf@fess.ebiederm.org> <m1bp7oq1u8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1bp7oq1u8.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2010 12:51 PM, Eric W. Biederman wrote:
> 
> Add a system call for creating sockets in a specified network namespace.

What for?
