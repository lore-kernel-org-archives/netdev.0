From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] net: dsa: mv88e6xxx: add number of database
 to info
Date: Fri, 15 Apr 2016 22:27:09 +0200
Message-ID: <20160415202709.GF18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-7-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160415193516.GD18523@lunn.ch>
 <87mvouaadh.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mvouaadh.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 04:24:26PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > On Fri, Apr 15, 2016 at 02:25:49PM -0400, Vivien Didelot wrote:
> >> Move the number of databases to the info structure.
> >
> > Isn't the number of databases a property of the family?
> 
> No.

O.K, then lets put it in the device info table.

     Andrew
