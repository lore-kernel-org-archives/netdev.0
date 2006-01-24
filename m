From: Stefan Seyfried <seife@suse.de>
Subject: e100 oops on resume
Date: Tue, 24 Jan 2006 23:59:19 +0100
Message-ID: <20060124225919.GC12566@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750811AbWAXXAs@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
since 2.6.16rc1-git3, e100 dies on resume (regardless if from disk, ram=
 or
runtime powermanagement). Unfortunately i only have a bad photo of
the oops right now, it is available from
https://bugzilla.novell.com/attachment.cgi?id=3D64761&action=3Dview
I have reproduced this on a second e100 machine and can get a serial
console log from this machine tomorrow if needed.
It did resume fine with 2.6.15-git12
--=20
Stefan Seyfried                  \ "I didn't want to write for pay. I
QA / R&D Team Mobile Devices      \ wanted to be paid for what I write.=
"
SUSE LINUX Products GmbH, N=FCrnberg \                    -- Leonard Co=
hen
