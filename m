From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth: version 0.17 available
Date: Tue, 18 Nov 2003 15:44:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBA3066.80508@gmx.net>
References: <3FB807A3.8010207@gmx.net> <3FB98C18.8090305@gmx.net> <3FB9A261.7080500@mcve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Brad House <brad_mssw@gentoo.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mcve.com>
In-Reply-To: <3FB9A261.7080500@mcve.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House wrote:
> Well, the problem I saw was with the 2.6 patch.
> 
> These lines:
> 
> +++ build-2.6/drivers/net/forcedeth.c    2003-11-15 23:00:30.000000000
> +0100
> @@ -0,0 +1,1416 @@
> 
> Should be
> 
> +++ build-2.6/drivers/net/forcedeth.c    2003-11-15 23:00:30.000000000
> +0100
> @@ -0,0 +1,1418 @@

Aaah! The files were corrupted during upload. That's why I didn't find the
problem you described in my local version.
The problem is fixed now and MD5 sums have been uploaded to avoid this in
the future.

Thanks again,
Carl-Daniel


> Carl-Daniel Hailfinger wrote:
> 
>> Carl-Daniel Hailfinger wrote:
>>
>>> version 0.17 of forcedeth for Linux 2.4 and 2.6 is available at
>>> http://www.hailfinger.org/carldani/linux/patches/forcedeth/
>>
>>
>>
>> The patches for Linux 2.4 were malformed. Corrected versions have been
>> uploaded a few hours ago.
>> Thanks to Brad House for spotting this.
