From: "gio zanei" <il_boba@hotmail.com>
Subject: token bucket filter for shaping ppp link
Date: Tue, 23 Apr 2002 15:22:38 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <F58Xg5wlSe9F6EBSotw000152d5@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi to all,
for my thesis i need to shape a ppp link as a UMTS link. That is i need  to 
configure the link so that i can control the packets that can be sent. 
Specifically i need to shape the line so that, at most, is going to pass one 
packet every 10msec. Is there any possibility also to choose, once the 
connection is up, how big the packets can be? Even, if they are too small, 
is there a possibility to put some stuffing bits to have the packets of the 
dimension i need?
I tried using the tc with tbf...but i don't understand very well what it has 
to be done for my needs. Is the mpu option useful?
Thank you,
boba

_________________________________________________________________
Conversa in chat con gli amici in linea, prova MSN Messenger: 
http://messenger.msn.com

