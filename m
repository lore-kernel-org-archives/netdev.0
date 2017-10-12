From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Linux 4.9.55 break network setup because dhcp client gets an
 error
Date: Thu, 12 Oct 2017 22:11:55 +0200
Message-ID: <20171012201155.GA26507@kroah.com>
References: <b4a1ec2d-d40d-555d-f1d6-74f96cbb405a@free.fr>
 <CAKocOOPvO4GjWPGVt+dUkti3=GruUz5eu3WXV8D-9fdF+KK0sg@mail.gmail.com>
 <CAM_iQpXcx3rzHf-vw_D0miPC+asUKWN8kUcXSQzgV8vMXHJpFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shuah Khan <shuahkhan@gmail.com>, eric.valette@free.fr,
        LKML <linux-kernel@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        David Miller <davem@davemloft.net>, shuahkh@osg.samsung.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXcx3rzHf-vw_D0miPC+asUKWN8kUcXSQzgV8vMXHJpFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 12:56:57PM -0700, Cong Wang wrote:
> (Cc'ing netdev and the author Eric)

Already fixed, try 4.9.56 :)

thanks,

greg k-h
