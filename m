From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Thu, 21 Jul 2016 10:44:37 -0400
Message-ID: <8737n3nj8q.fsf@ketchup.mtl.sfl>
References: <20160720222641.30899-1-vivien.didelot@savoirfairelinux.com> <20160721003545.GB22834@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160721003545.GB22834@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>>  net/dsa/dsa.c                    |  985 ------------------------------------
>>  net/dsa/legacy.c                 | 1013 ++++++++++++++++++++++++++++++++++++++
>
> I'm surprised git did not notice this is a rename.

I used -M though, even -C doesn't change anything... :-/
