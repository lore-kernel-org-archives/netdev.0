From: Casey Carter <Casey@Carter.net>
Subject: Re: finding out what NIC a socket connection came in on
Date: Tue, 09 Apr 2002 21:26:21 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CB3A2CD.8040404@Carter.net>
References: <20020410001830.64699.qmail@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hahn@physics.mcmaster.ca, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Lee Chin <leechin@mail.com>
List-Id: netdev.vger.kernel.org

Lee Chin wrote:

>Hi,
>I have a box with 2 NICs.  I have a server that does a socket accept.  I would like to know which NIC a new socket connection originated from.  How can I do this?
>
>Thanks
>Lee
>
man 2 accept

-- 
Casey Carter
Casey@Carter.net
ccarter@uiuc.edu
AIM: cartec69



