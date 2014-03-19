From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] USB: cdc: add MBIM extended functional
 descriptor structure
Date: Wed, 19 Mar 2014 16:05:08 -0400 (EDT)
Message-ID: <20140319.160508.1651223181779271745.davem@davemloft.net>
References: <1395115145-31821-1-git-send-email-benchan@chromium.org>
	<87wqfrkioi.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: benchan@chromium.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org, gregkh@linuxfoundation.org,
	gsuarez@smithmicro.com
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wqfrkioi.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 18 Mar 2014 09:35:57 +0100

> Or will patchwork keep track of tags across different patch
> versions?

It doesn't, and should not.  It has no idea if the patch changed or
not, the ACK'er might not still agree with the patch if any changes
were made.
