From: sudeep list <sudeep.list@gmail.com>
Subject: pointers in the sk_buff structure.
Date: Thu, 3 Feb 2005 15:45:15 -0700
Message-ID: <d50018af05020314451010c5eb@mail.gmail.com>
Reply-To: sudeep list <sudeep.list@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,

I figured that the pointer sk_buff->tail points to the end of data in
the buffer attached to the sk_buff. What does the pointer sk_buff->end
point to ?

Is there any data that lies between the two pointers, or they are two
pointers to the same address (end of data in the buffer area) ?

Sudeep
