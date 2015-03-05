From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Thu, 05 Mar 2015 13:34:56 -0500
Message-ID: <54F8A1D0.308@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alex Elsayed <eternaleye@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F5EF6E.9090303@digirati.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 >>    We have been developing Linux XIA, a new network stack that
 >> emphasizes evolvability and interoperability, for a couple of years,
 >> and it has now reached a degree of maturity that allows others to
 >> experiment with it.
 >
 > From looking at your wiki, "network stack" may have been a poor
 > choice of term - it looks like rather than being a new network
 > stack (which in Linux, is commonly used to refer to the software
 > stack that lives between the APIs and the hardware), this is a
 > new protocol (and framework _for_ protocols) operating at
 > the same level of the network as IP, with ideas extending
 > upwards through TCP.
 >
 > Now, that's a rather different proposal - witness that RDS, TIPC,
 > etc all made it into the kernel relatively easily, especially when
 > compared to netmap, or any other system that tried to replace
 > the Linux networking infrastructure.

Hi Alex,

    Thank you very much for having caught this definition mismatch! I 
personally see TCP/IP as a network stack on its own right. From this 
perspective, XIA, TCP/IP, RDS, and TIPC are all at the same level as you 
concluded. I don't mind adopting the definitions that are more common 
among kernel developers.

    Linux XIA is not replacing the other protocols (using your 
definition). Linux XIA is another protocol, and, as you correctly 
pointed out: a framework for other protocols.

[ ]'s
Michel Machado
