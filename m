From: lejeczek <peljasz@yahoo.co.uk>
Subject: on the the two IPs unreachable if second interface is up
Date: Fri, 25 May 2012 16:12:50 +0100
Message-ID: <4FBFA172.2060604@yahoo.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm16-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.254]:37750
	"HELO nm16-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751305Ab2EYPMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 11:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello everybody

apologies if this may feel off the topic, I was hoping some 
net experts could shed some lights on some peculiar symptoms 
I experience with one linux box

a BOX has two net interfaces, a public and private one
public IP is reachable from/via the Internet just fine
public IP is not reachable from the same private network the 
BOX's second interface is on
public IP becomes reachable to private subnet immediately 
after second(private) interface was turned down
BOX's firewall whether on or off makes no difference

this is the most peculiar problem of this nature I've ever 
experienced

the goal is simple, have other systems on the same private 
subnet as the BOX's second interface to be able to talk to 
the BOX's public IP
default gateway for the private subnet is a separate another 
system.

any suggestions as to how to troubleshoot it I would very! 
much appreciate
many thanks!
