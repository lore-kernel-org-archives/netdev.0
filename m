From: Helmut Berger <Helmut.BA.Berger@partner.bmw.de>
Subject: Inserting a layer between TCP and IP
Date: Tue, 02 Dec 2003 17:11:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070381465.1793.16.camel@ztpc451-L.MUC>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I am not sure if this is the right platform for my question. I am not
very familiar with linux driver development. If I am wrong here, please
be so kind and tell me, where I should better go to. 
I want to insert an additional layer between the tcp and ip layer with
some special functionality and I am not sure how to do this. I fear it
cannot be done with system_calls, can it? That would be very
comfortable. I could write a loadable kernel module which registers
itself on insert and deregisters itself on remove. 
Is it possible to insert my special layer at runtime without kernel
changes? 
Or do I have to build a special kernel? 
Which ist the best way to insert a layer between the existing tcp and ip
layer?
Thanx, Helmut
