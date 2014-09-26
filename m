From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: FIXMEs in rt2800lib.c
Date: Fri, 26 Sep 2014 14:22:08 +0200
Message-ID: <20140926122207.GA27809@redhat.com>
References: <5424566B.6000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: IvDoorn@gmail.com, helmut.schaa@googlemail.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nick <yocto6@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5424566B.6000206@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 25, 2014 at 01:52:43PM -0400, nick wrote:
> I seem to be hitting to fix mes in the file I listed in the subject. Would someone tell me if it's Ok to remove
> the lines that over write certain registers.

No, as long you prove that they are not needed.

Stanislaw
