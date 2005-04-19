From: Alex Aizman <itn780@yahoo.com>
Subject: Re: [ANNOUNCE] Linux-iSCSI High-Performance Initiator
Date: Tue, 19 Apr 2005 07:34:54 -0700
Message-ID: <4265170E.5040102@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Input is needed...

Two weeks ago the combined linux-iscsi and open-iscsi teams posted
on lkml and linux-scsi "Linux-iSCSI High-Performance Initiator" - 
announcement and a set of patches.

Here's the original announcement and the submission, respectively:

http://marc.theaimsgroup.com/?l=linux-kernel&m=111327337005048&w=2

http://marc.theaimsgroup.com/?l=linux-kernel&m=111328256211837&w=2

The entire iSCSI Initiator's data path over TCP consists of 2 files:

http://www.open-iscsi.org/src/iscsi_tcp.c

http://www.open-iscsi.org/src/iscsi_tcp.h

(The first file is 73K, I sent yesterday - seems it didn't make it).

It'd be great to get this code reviewed from the networking perspective.

Thanks!
Alex
