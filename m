From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Wed, 06 Jan 2010 07:12:50 +0100
Message-ID: <m27hrvoj6l.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<20100104184241.GC6034@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100104184241.GC6034@us.ibm.com> (Serge E. Hallyn's message of
	"Mon, 4 Jan 2010 12:42:41 -0600")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Samir Bellabes (sam@synack.fr):
>> +
>> +MODULE_DESCRIPTION("snet - Security for NETwork syscalls");
>
> Would 'usnet' or 'ucsnet' - userspace-controlled security for
> network syscalls - be more informative?

maybe a better suitable name is required. discussion is opened :)
'snet' was short.
