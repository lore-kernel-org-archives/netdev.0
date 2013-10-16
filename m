From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: qmi_wwan: Olivetti Olicard 200 support
Date: Wed, 16 Oct 2013 13:24:28 -0700
Message-ID: <20131016202428.GA24399@kroah.com>
References: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com>
 <1381842408-10800-2-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bjorn@mork.no, dcbw@redhat.com,
	christian.schmiedl@gemalto.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonella Pellizzari <anto.pellizzari83@gmail.com>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381842408-10800-2-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2013 at 03:06:48PM +0200, Enrico Mioso wrote:
> This is a QMI device, manufactured by TCT Mobile Phones.
> A companion patch blacklisting this device's QMI interface in the option.c
> driver has been sent.
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
> Signed-off-by: Antonella Pellizzari <anto.pellizzari83@gmail.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
