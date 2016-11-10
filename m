From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Thu, 10 Nov 2016 21:38:04 +0100
Message-ID: <87zil7f4ur.fsf@miraculix.mork.no>
References: <Pine.LNX.4.44L0.1611101035140.1667-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        Oliver Neukum <oneukum@suse.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1611101035140.1667-100000@iolanthe.rowland.org>
        (Alan Stern's message of "Thu, 10 Nov 2016 10:36:18 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Stern <stern@rowland.harvard.edu> writes:
> On Thu, 10 Nov 2016, Kai-Heng Feng wrote:
>
>> Is there a way to force XHCI run at HighSpeed?
>
> Yes, like I said above: Use a USB-2 cable instead of a USB-3 cable.

It's an m.2 form factor modem, so there most likely isn't any cable
involved.  But the principle is the same: Cover the USB3 diff pair pins
with a piece of tape.



Bj=C3=B8rn
