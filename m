From: Bjarke Istrup Pedersen <gurligebis@gmail.com>
Subject: p54: Weird error in log
Date: Tue, 10 Apr 2012 23:30:40 +0200
Message-ID: <CACPM=kXvq9eJj19MMW-G3hu4Qro_Z53YKWhxN24YqGFX6706kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I keep getting this error in my dmesg log:

p54pci 0000:00:0e.0: rx'd frame size exceeds length threshold

The p54 card is bridged together with two via-rhine network cards, to
create an access point.

The card seems to work fine - it is just that this message floods the
logs - I could comment it out in the driver, but it would make more
sense to figure out if it is a bug that causes it to get hit, or a
configuration issue.

Any ideas?

/Bjarke
