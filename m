From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Thu, 25 Feb 2010 12:27:21 -0600
Message-ID: <1446F46F-683F-49F7-BBD4-2113A26B0DAB@kernel.crashing.org>
References: <4B6C2488.3060403@ge.com> <4B865176.7080806@ge.com> <4B86A97E.6050509@ge.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net
To: Martyn Welch <martyn.welch@ge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B86A97E.6050509@ge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 25, 2010, at 10:46 AM, Martyn Welch wrote:

> 
> Further testing has shown that this isn't restricted to warm reboots, it
> happens from cold as well. In addition, the exact timing of the failure
> seems to vary, some boots have got further before failing.

what mechanism do you use for warm resets?

- k
