From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 5/6] net: dsa: push prepare phase in port_fdb_add
Date: Wed, 7 Oct 2015 23:19:52 -0700
Message-ID: <CAE4R7bAV7dDrFUQc=Za3kL=VPkgXV9P37rUMGoa4JFQNT_7LEA@mail.gmail.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444261711-1829-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 7, 2015 at 4:48 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Now that the prepare phase is pushed down to the DSA drivers, propagate
> it to the port_fdb_add function.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
