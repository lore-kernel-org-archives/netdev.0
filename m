From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: remove bridge work
Date: Tue, 17 May 2016 12:23:34 -0400
Message-ID: <87a8jozm9l.fsf@ketchup.mtl.sfl>
References: <1463186303-3139-1-git-send-email-vivien.didelot@savoirfairelinux.com> <8737plig1v.fsf@ketchup.mtl.sfl> <20160516.134823.1909596879203571371.davem@davemloft.net> <87r3d01yok.fsf@ketchup.mtl.sfl> <20160517160358.GC26948@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	f.fainelli@gmail.com, jiri@resnulli.us
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160517160358.GC26948@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> Do we want to send this fix to -net as well?
>
> I don't see this bug as being highly critical that it needs to be
> fixed immediately.
>
> I would suggest we wait until -rc1 is out, and then produce a backport
> version. Given the changes we have made to that driver, there is
> little chance the existing fix will cherry-pick backwards.

Sounds good to me!

Thanks,

        Vivien
