From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Thu, 10 Feb 2005 14:36:40 -0800
Message-ID: <420BE1F8.1080500@hp.com>
References: <0523RGW12@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
In-Reply-To: <0523RGW12@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hubert Tonneau wrote:
> It does not seem to solve the problem:
> . Linux 2.6.9 takes 15 seconds to copy 105 MB to the Mac OSX
> . Linux 2.6.10 with the TCP patch still takes 325 seconds.


is there a packet trace somewhere?
rick jones
