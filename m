From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 1/12] S2io: cosmetic changes
Date: Thu, 28 Oct 2004 19:33:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418181D9.5010603@pobox.com>
References: <003c01c4bd40$76171f80$9810100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com, alicia.pena@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <003c01c4bd40$76171f80$9810100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With this new resend, I tried with both my automated scripts, and 
applying manually as well.

All attempts succeed on patches #1 and #2, but fail on #3 - #12.

If I manually add the "-l" argument to patch(1), then patch #3 succeeds. 
  That implies that somewhere in your process, whitespace in your 
patches is getting corrupted.

	Jeff
