From: tanmay ganacharya <ganachar@usc.edu>
Subject: Units of the value in t_rtttime and t_rxtcur
Date: Tue, 13 Jan 2004 14:38:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <837c3083b839.83b839837c30@usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-language: en
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I am working on a project in which I need to find the instantaneous RTT's and RTO's over a period of 20 Minutes of a TCP connection.
I was able to get the RTT and RTO values from the t_rtttime and t_rxtcur variables in the tcp block structure but am not able to figure out the units of the values.
I need to get both in same units.
I think RTO's are in ticks. But am not very sure about RTT.
Please could you help me with the same. I would really be grateful.
Also I found that 1 TCP tick = 224 miliseconds. I just wanted to confim whether it is correct. I am using FreeBSD 4.9 Stable.
I am sending a sample of the values I have collected.

t_rtttime = 354397342, t_srtt = 68069, t_rxtcur = 1689

Waiting for your reply.
Thanking you,
Yours truly,
Tanmay Ganacharya
