From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Silent corruption with r8169
Date: Wed, 4 Apr 2007 22:45:53 +0200
Message-ID: <20070404204553.GD7814@electric-eye.fr.zoreil.com>
References: <20070401012736.GT15189@vitelus.com> <20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com> <p737iswqjq4.fsf@bingen.suse.de> <20070404184504.GB7814@electric-eye.fr.zoreil.com> <20070404200603.GX15189@vitelus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jim Paris <jim@jtan.com>,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org
To: Aaron Lehmann <aaronl@vitelus.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070404200603.GX15189@vitelus.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron Lehmann <aaronl@vitelus.com> :
[...]
> I'll try to get to testing this, but I'm wondering if people may have
> misunderstood my original post. I don't get any corruption over
> Ethernet; it's just corruption on the filesystem during certain load
> patterns that involve the Realtek ethernet card.

It is too soon to label it a debug feature or a genuine bug in the
r8169 driver but at least there is a r8169 patchkit to help with
various annoyances (obscure bug on amd platform for instance).
It could make a difference.

The disk io + r8169 driver bugs can be very frustrating to debug :o/

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
