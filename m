From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 21:15:50 -0500 (EST)
Message-ID: <20120228.211550.1312387402784932237.davem@davemloft.net>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
	<20120228.205347.1718771650331094141.davem@davemloft.net>
	<CAB=NE6VXyQ-k1Sm3Xf_ABE35+PHSoNqX=AJpLBjNu0sdAdnY4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: rodrigue@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6VXyQ-k1Sm3Xf_ABE35+PHSoNqX=AJpLBjNu0sdAdnY4g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Date: Tue, 28 Feb 2012 18:12:31 -0800

> I *vehemently* tried to change direction of this driver development to
> do exactly what you stated when this driver was first posted last year
> in October of 2011 [0]. I could not get commitment on that route
> mainly due to the large delta and lack of resources to address this.

Oh well, that's unfortunate.  Broadcom gave us a similar song and
dance 10 years or so ago when they tried to do the same thing.

We saw what happened then, and I know what Qualcomm will do in the
end.  It's just a matter of time for how long it will take Qualcomm
to relent and do the right thing and properly maintain the atl1c
driver.

The good news is that I'm incredibly patient.
