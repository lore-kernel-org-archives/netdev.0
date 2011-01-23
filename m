From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Sun, 23 Jan 2011 13:29:02 -0800
Message-ID: <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simon Arlott <simon@fire.lp0.eu>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: maciej.rutecki@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101231845.20505.maciej.rutecki@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 23, 2011 at 9:45 AM, Maciej Rutecki
<maciej.rutecki@gmail.com> wrote:
> I created a Bugzilla entry at
> https://bugzilla.kernel.org/show_bug.cgi?id=27432
> for your bug report, please add your address to the CC list in there, thanks!

This isn't a bug - the change resolved behavior that varied depending
on what NIC was in use.
