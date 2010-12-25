From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 00/15][pull-request] Intel Wired LAN Driver Update
Date: Fri, 24 Dec 2010 22:35:17 -0800
Message-ID: <AANLkTikGX1CjheM9qgVy5c9y9MSTTcQCgz=3NjgM_Ds1@mail.gmail.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38081 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab0LYGfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 01:35:18 -0500
Received: by iyi12 with SMTP id 12so6228288iyi.19
        for <netdev@vger.kernel.org>; Fri, 24 Dec 2010 22:35:17 -0800 (PST)
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 24, 2010 at 22:05,  <jeffrey.t.kirsher@intel.com> wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> The following series addresses the more significant issues reported b=
y
> checkpatch when run against the e1000e driver files. =C2=A0The less s=
erious
> whitespace and lines over 80 characters issues are not addressed. =C2=
=A0In
> addition, added support for anti-spoofing and X540 SR-IOV.
>
> The remaining warnings for msleep < 20ms will be addressed in a follo=
w-on
> patch after a thorough investigation into the timings tolerated by th=
e
> hardware.
>
> The following changes since commit e1928c86c4829703b800c81cc9edc939b5=
634e6f:
>
> =C2=A0cnic: Add FCoE support on 57712
>
> are available in the git repository at:
>
> =C2=A0master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2=
=2E6.git master

=2E.. and happy holidays everyone!
