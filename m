From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] net: fec: Add "phy-reset-active-low" property to DT
Date: Fri, 12 Feb 2016 13:24:11 -0200
Message-ID: <CAOMZO5CQmVf7EuOWY+e_+jWjzxXodpTcahJBnzP0x1uapO+okQ@mail.gmail.com>
References: <1455048072-869-1-git-send-email-bernhard@bwalle.de>
	<20160212152011.GA28563@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bernhard Walle <bernhard@bwalle.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160212152011.GA28563@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 1:20 PM, Rob Herring <robh@kernel.org> wrote:

> This is what the gpio flags are for. Why can't you use that?

This has already been discussed in v1:
https://lkml.org/lkml/2016/2/8/867
