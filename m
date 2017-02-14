From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/4] ptp: do not explicitly set drvdata in
 ptp_clock_register()
Date: Tue, 14 Feb 2017 09:30:31 +0100
Message-ID: <20170214083031.GA8048@localhost.localdomain>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry,

Be sure to put davem onto CC next time, as he merges any PTP work.

On Mon, Feb 13, 2017 at 07:51:05PM -0800, Dmitry Torokhov wrote:
> We do not need explicitly call dev_set_drvdata(), as it is done for us by
> device_create().

Acked-by: Richard Cochran <richardcochran@gmail.com>
