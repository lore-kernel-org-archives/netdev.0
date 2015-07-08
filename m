From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Wed, 8 Jul 2015 16:34:33 -0400 (EDT)
Message-ID: <707426774.108902.1436387673690.JavaMail.zimbra@savoirfairelinux.com>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150708143805.GA32208@lunn.ch> <894793886.88178.1436375596747.JavaMail.zimbra@savoirfairelinux.com> <20150708173216.GB1357@lunn.ch> <1831874541.91682.1436379099609.JavaMail.zimbra@savoirfairelinux.com> <20150708201244.GE1357@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708201244.GE1357@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

----- On Jul 8, 2015, at 4:12 PM, Andrew Lunn andrew@lunn.ch wrote:

>> I understand. However this whole VLAN thing represents a lot of code.
>> Some other work depends on portions of it. Do you think it'd be OK if I
>> resend the patch 1/3 alone? Having only the VTU operations and "vtu"
>> debugfs file does not break the actual behavior, and will lighten up the
>> following patchsets.
> 
> It might be a bit early for that. All the previous versions of 1/3
> have had issues with number of ports. I've not had time to take a
> close look to see if there are other problems.
> 
> If somebody else does a proper review and says its O.K, them i'm
> O.K. with that. But until that happens, i don't think it should go in.
> 
>      Andrew

OK, then I'll send right away smaller debugfs patches that I need.
Hopefully you'll have time to review it before your holidays ;-)

Also, I'll resend the VTU debugfs support later then.

Thanks,
-v
