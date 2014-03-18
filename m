From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: cdc_ncm: respect operator preferred MTU
 reported by MBIM
Date: Mon, 17 Mar 2014 21:41:48 -0400 (EDT)
Message-ID: <20140317.214148.2254695408331774828.davem@davemloft.net>
References: <CAC5Y2nN_w46FczgitbPjmXtk7q3rHpTxLddx0_GtStfzNXerXQ@mail.gmail.com>
	<87d2hkldmx.fsf@nemi.mork.no>
	<CAC5Y2nMdPM8w3=dgd2as5z8huL1XLPjon8wSmR-2e3=JGWtCpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org, gregkh@linuxfoundation.org,
	gsuarez@smithmicro.com
To: benchan@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAC5Y2nMdPM8w3=dgd2as5z8huL1XLPjon8wSmR-2e3=JGWtCpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Chan <benchan@chromium.org>
Date: Mon, 17 Mar 2014 17:46:27 -0700

> Thanks again for the review and tip. I've submitted patch v2 to
> address the le16_to_cpu conversion.

When you update a patch from a series, you should repost the entire
patch set, rather than just the patch which changes.

This avoids any and all ambiguity of which patches go with which
others.
