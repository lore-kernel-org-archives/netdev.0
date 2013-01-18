From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch v2] b43: N-PHY: fix gain in b43_nphy_get_gain_ctl_workaround_ent()
Date: Fri, 18 Jan 2013 13:53:43 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7118@saturn3.aculab.com>
References: <50F84AF3.5070901@bfs.de> <20130118133658.GA31186@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <b43-dev@lists.infradead.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>,
	"Stefano Brivio" <stefano.brivio@polimi.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20130118133658.GA31186@elgon.mountain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +		int gain_data[] = {0x0062, 0x0064, 0x006a, 0x106a, 0x106c,
> +				   0x1074, 0x107c, 0x207c};

static const int ...

	David
