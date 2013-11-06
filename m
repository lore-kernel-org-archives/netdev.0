From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] wcn36xx: Fix logging macro with unnecessary semicolon
Date: Wed, 06 Nov 2013 09:55:56 -0800
Message-ID: <1383760556.7940.28.camel@joe-AO722>
References: <1383684000.4387.42.camel@joe-AO722>
	 <CAFSJ42YQy96Sko8CuG9BGjHzTV7TkRp2=NVt036APxSKpPB=Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath5k-devel@lists.ath5k.org,
	ath9k-devel <ath9k-devel@lists.ath9k.org>,
	ath10k@lists.infradead.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFSJ42YQy96Sko8CuG9BGjHzTV7TkRp2=NVt036APxSKpPB=Ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-06 at 07:49 +0000, Eugene Krasnikov wrote:
> Hm... when it comes to semicolon the patch seems to be good. When it
> comes to dynamic debugging i think we should have a separate
> discussion about that.
> I personally like the whole idea about dynamic debug but if you want
> to change it i would suggest to have some kind of framework for all
> ath drivers(or maybe all wireless drivers). Because obviously you can
> find common code in every driver that defines it's own debug
> functions/debug levels and so on. Why not to make a framework with
> standard API/levels?

You need to bring that up with the Atheros folk.
I've tried.  The view seemed to be it was more
trouble than it was worth.
