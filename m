From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Mon, 10 Aug 2015 09:39:24 -0400
Message-ID: <20150810133924.GA10802@ketchup.touchtunes.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150809.224822.1627697290087246344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com, sfeldma@gmail.com, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150809.224822.1627697290087246344.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 15-08-09 22:48:22, David Miller wrote:
> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Thu,  6 Aug 2015 01:44:01 -0400
> 
> > This patchset refactors the DSA and mv88e6xxx code to use the switchdev FDB
> > objects.
> 
> Series applied, thanks.

I noticed you didn't push the serie yet. I've just sent the v3 which
includes the switchdev change (ndm_state) mentioned by Scott and the
reordering of commits to improve bisectability, as suggested by Andrew.

Please consider the v3 "[PATCH net-next v3 0/8] net: dsa: mv88e6xxx:
support switchdev FDB objects" instead.

Thanks,
-v
