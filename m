From: Parag Nemade <cranium2003@yahoo.com>
Subject: kernel development netwrok protocol modification
Date: Sat, 3 Apr 2004 07:07:11 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040403150711.81930.qmail@web41414.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello friends,
            I want to add my own routine to network
protocol stack. 
What i want to do i will explain you. For each and
every packet that outgoes from kernel i want to attach
a 8 byte of my own checksum to data part in packet.
This ensures that data is to be transmitted correctly
across computers.
Can anybody help me where i have to insert my code in
kernel source tree cause there are 3 programs to be
included in which one exchanges keys adjecent
computers. second calculates checksum on basis of that
key. and third checks packet replay. 
I wish to be personally CC'ed the answers/comments
posted to the list in response to my posting.

regards,
Parag.



__________________________________
Do you Yahoo!?
Yahoo! Small Business $15K Web Design Giveaway 
http://promotions.yahoo.com/design_giveaway/
