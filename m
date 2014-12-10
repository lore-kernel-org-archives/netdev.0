From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Add support for CAN presume-ack feature
Date: Tue, 9 Dec 2014 20:35:19 -0800
Message-ID: <20141209203519.7f0ff71c@urahara>
References: <1417766390-4587-1-git-send-email-nebaruzdin@gmail.com>
	<1417768902-5404-1-git-send-email-nebaruzdin@gmail.com>
	<1417768902-5404-2-git-send-email-nebaruzdin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Nikita Edward Baruzdin <nebaruzdin@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1417768902-5404-2-git-send-email-nebaruzdin@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  5 Dec 2014 11:41:42 +0300
Nikita Edward Baruzdin <nebaruzdin@gmail.com> wrote:

> This patch makes CAN_CTRLMODE_PRESUME_ACK netlink feature configurable.
> When enabled, the feature sets CAN controller in mode in which
> acknowledgement absence is ignored.
> 
> Signed-off-by: Nikita Edward Baruzdin <nebaruzdin@gmail.com>
> ---

Applied.
