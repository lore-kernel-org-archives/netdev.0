From: "kartikey bhatt" <kartik_me@hotmail.com>
Subject: two questions
Date: Sun, 04 Jul 2004 09:27:33 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY16-F40l05rz79Xyt0000a8d4@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have two questions.

(1) in bsd when a socket is created, the process
creating the socket is passed as a structure
to so_create call. in linux how can we have
this mechanism by which when a socket is created
we can access the task_t of the process creating the
socket?

(2) given the sk_buff* how to lookup the associated
socket?

can anyone please help me out.

--Bhatt Kartikey Mahendra

_________________________________________________________________
Looking for a soulmate? http://www.shaadi.com/ptnr.php?ptnr=hmltag Log onto 
shaadi.com
