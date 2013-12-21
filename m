From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/5] drivers: net: APM X-Gene SoC Ethernet base driver
Date: Sat, 21 Dec 2013 13:11:58 -0800
Message-ID: <20131221211158.GB30102@kroah.com>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
 <1387597376-29303-4-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387597376-29303-4-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 07:42:54PM -0800, Iyappan Subramanian wrote:
> Ethernet base device driver for APM X-Gene SoC.

Why is this a platform driver and not a bus driver for a xgene device?

thanks,

greg k-h
