From: Jason Lunz <lunz@falooley.org>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Fri, 12 Jul 2002 15:11:58 +0000 (UTC)
Sender: owner-netdev@oss.sgi.com
Message-ID: <slrnaitsfh.7vj.lunz@stoli.localnet>
References: <Pine.LNX.4.44.0207111238570.2498-100000@beohost.scyld.com> <3D2DBDA4.4090009@candelatech.com> <3D2DCF1B.9050108@mandrakesoft.com> <3D2E0754.1060107@candelatech.com>
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

greearb@candelatech.com said:
>> I thought that issue was fixed in 2.4.19-rc1?  Can you verify the 
>> problem still exists?
>>     Jeff
> I have not tried with rc1, so it very well could be fixed.

The 2.4.19-rc1 sundance driver (sundance.c:v1.01b 17-Jan-2002) does not
work with my DLink 4-port DFE-580TX. As Donald mentioned earlier, newer
Kendin sundance chips have a finicky on-chip transceiver. I'll be
testing various sundance drivers on this card today.

Jason
