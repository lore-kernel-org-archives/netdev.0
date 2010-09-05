From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sun, 5 Sep 2010 09:20:41 +0200
Message-ID: <20100905072041.GA2928@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <alpine.DEB.2.00.1009041221240.888@router.home>
 <4C828652.4060804@gmail.com>
 <alpine.DEB.2.00.1009042042130.9425@router.home>
 <20100905062240.GB2699@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Riesch <christian.riesch@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100905062240.GB2699@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 05, 2010 at 08:22:40AM +0200, Richard Cochran wrote:
> At this point, I think it is clear that, in order to support IEEE
> 1588, some kind of changes are needed. I have argued and discussed the

Just to be absolutely clear, I should have said, "hardare clocks for
IEEE 1588." The aim of the patch set is to support a new kind of
hardware.

> Having said that, if you are convinced that the existing interfaces
> are good enough to support PTP (and possible future methods, as

Again, I meant "PTP hardware clocks."

When I get some more time, I'll try to put together an executive
summary of PTP and of all the discussions that have taken place over
the last few months on linux-netdev and the lkml.

Richard
