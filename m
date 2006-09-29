From: Samuel Tardieu <sam@rfc1149.net>
Subject: Re: [ACRYPTO] New asynchronous crypto layer (acrypto) release.
Date: 29 Sep 2006 12:17:58 +0200
Message-ID: <87wt7nm0x5.fsf@willow.rfc1149.net>
References: <20060928120826.GA18063@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751075AbWI2KUp@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Evgeniy" == Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

Evgeniy> Hello.  I'm pleased to announce asynchronous crypto layer
Evgeniy> (acrypto) [1] release for 2.6.18 kernel tree. Acrypto allows
Evgeniy> to handle crypto requests asynchronously in hardware.

Would userspace programs benefit from this patch? In particular, would
OpenSSL get better performances on Via nehemiah CPUs or does it need
to be patched?

  Sam
-- 
Samuel Tardieu -- sam@rfc1149.net -- http://www.rfc1149.net/
