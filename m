From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 12:58:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99D44F.2010001@nortelnetworks.com>
References: <200210011531.TAA19943@sex.inr.ac.ru> <3D99D061.1090208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

> I cannot see any logical reason that we cannot ensure that a packet is
> not at least given to the driver when accepted by sendto.  As soon as I
> get my pktgen and send-to-self code cleaned up, I am planning to start
> working on making UDP reliably send packets, or return an error to
> the calling code.  I will, of course, keep you informed if I actually
> get something working...


That would be fantastic.

Chris
