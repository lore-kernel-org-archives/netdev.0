From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:45:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE4880.3080505@us.ibm.com>
References: <OFF1F6B3DC.30C0E5DE-ON85256D47.007AEFAF@us.ibm.com> <20030616.152745.124055059.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, stekloff@us.ibm.com, janiceg@us.ibm.com,
   jgarzik@pobox.com, kenistonj@us.ibm.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030616.152745.124055059.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Janice Girouard <girouard@us.ibm.com>
>    Date: Mon, 16 Jun 2003 17:29:15 -0500
>    
>    For the sake of consistency and automatic error log analysis, it might be
> 
> And all the scripts checking for the existing messages
> in log files?  Screw them, right?

Are you saying we never get to change any current
log messages ever again on accnt of the scripts that are
monitoring for those precise words? Hope not :)

I'd agree a lot of thought (and agreement :))has to go
into this before changing minor nits and stuff, and not
causing too much disruption..Evolution, as opposed to
revolution ;).  I would hope that most wouldnt need changing..

thanks,
Nivedita
