From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: via-rhine: Problem with lost link after a while
Date: Tue, 10 Apr 2012 17:03:26 +0200
Message-ID: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Francois,

There seems to be a few problems with the new via-rhine driver.

After going to 3.3, it seems to drop link from time to time (randomly
it seems) - this didn't happen when I was running the patches from you
on top of 3.2 when we where testing them back in january.

It seems like other people have having a few problems too:
https://bugzilla.redhat.com/show_bug.cgi?id=805801 and on the
soekris-tech mailing list today (the archive hasn't been updated, so I
cannot post a link yet)

Got any ideas?

I'm ready to help testing if needed.

/Bjarke
